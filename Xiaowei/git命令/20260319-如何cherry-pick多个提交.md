## 1. 列出多个提交（适用于不连续的提交）

直接列出所有想要cherry-pick的提交哈希，按空格分隔，Git会按你指定的顺序依次应用：

```bash
git cherry-pick <commit-hash1> <commit-hash2> <commit-hash3>
```



## 2. 指定提交范围（适用于连续的提交）

使用`..`语法选择一个连续的提交范围。注意：需要包含起始提交时，要在起始提交后加`^`：

```bash
# 包含从 A 到 B 的所有提交（包括 A 和 B）
git cherry-pick <start-commit>^..<end-commit>

# 不包含起始提交（A 不被包含，B 被包含）
git cherry-pick <start-commit>..<end-commit>
```



## 3. 合并为一个提交（可选）

如果你不想为每个被cherry-pick的提交都生成一个新提交，而是希望将所有更改合并为**一个提交**，可以使用`-n`（或`--no-commit`）选项：

```bash
git cherry-pick -n <commit-hash1> <commit-hash2>
git commit -m "合并多个提交的更改"
```



## 注意事项

- **执行前确保工作区干净**：最好没有未提交的更改，否则可能产生冲突或操作失败
- **提交顺序**：Git会严格按照你指定的顺序应用提交，如果有依赖关系，需确保顺序正确
- **处理冲突**：如果过程中出现冲突，Git会暂停。解决后使用`git add`暂存，然后执行`git cherry-pick --continue`继续，或使用`--abort`取消整个操作
